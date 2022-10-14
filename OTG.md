# NANOG-86 Hackathon Open Traffic Generator Lab

## Prerequisites

* Linux host or VM with sudo permissions and Docker support
* `git` - how to install depends on your Linux distro
* [Docker](https://docs.docker.com/engine/install/)
* [Containerlab](https://containerlab.dev/install/)
* [otgen](https://otg.dev/clients/otgen/) version 0.3.0 or later

    ```Shell
    curl -L "https://github.com/open-traffic-generator/otgen/releases/download/v0.3.0/otgen_0.3.0_$(uname -s)_$(uname -m).tar.gz" | tar xzv otgen
    sudo mv otgen /usr/local/bin/otgen
    sudo chmod +x /usr/local/bin/otgen
    ```

## OTG Containerlab topology 

The lab uses Containerlab topology file [`nanog_clab_otg_202210.yml`](nanog_clab_otg_202210.yml) with `ixia-c` traffic generator node. This node has replaced `host1` and `host2` from the [original NANOG-86 hackathon setup](nanog_clab_graphite_20221007_2.yaml).

With `ixia-c` node added, it becomes possible to introduce emulated network devices and traffic endpoints behind `ixia-c` ports. Such emulation brings more realism to the setup and allows to perform validation of the lab configuration.

For example, we can add an emulated router with a /24 network behind each `ixia-c` port. A diagram of this configuration is shown below. To define such emulated network elements with `ixia-c`, a configuration file [`otg.yml`](otg.yml) has to be applied to it. The file has to follow [Open Traffic Generator](https://otg.dev) specification.

![Diagram](images/n86-otg.png)

## Deploy

1. Use Containerlab to launch the topology

  ```Shell
  sudo -E clab dep -t nanog_clab_otg_202210.yml
  ```

2. Pull MAC addresses from the running topology. Here, to we're using an API call to the `graphite` container to collect live node data information, including MAC addresses, from the running nodes.

  ```Shell
  curl -s http://localhost:8080/collect/clab/nanog86_otg/nodes/ > node-data.json
  DMAC1=`cat node-data.json | jq -r '.nodes[] | select(.hostname=="crpd1") | .interfaces["eth3"].mac_address'`
  DMAC2=`cat node-data.json | jq -r '.nodes[] | select(.hostname=="ceos2") | .interfaces["Ethernet3"].mac_address'`
  echo $DMAC1 $DMAC2
  ```
## Create OTG configuration

1. Initialize test parameters via ENV variables

  ```Shell
  OTG_API="https://clab-nanog86_otg-ixiac"
  HOST1=10.100.0.2
  HOST2=10.100.1.2
  GW1=10.100.0.1
  GW2=10.100.1.1

  TESTIP1=198.51.100.1
  TESTIP2=192.0.2.1
  ```

2. Use `otgen` tool to generate `otg.yml` file with the test parameters defined above:

  ```Shell
  otgen create device --name otg1 --ip $HOST1 --gw $GW1 --port p1 --location eth1 | \
  otgen add device    --name otg2 --ip $HOST2 --gw $GW2 --port p2 --location eth2 | \
  otgen add flow --name f1 --dmac $DMAC1 \
                    --src $TESTIP1 --dst $TESTIP2 \
                    --tx otg1 --rx otg2 | \
  otgen add flow --name f2 --dmac $DMAC2 \
                    --src $TESTIP2 --dst $TESTIP1 \
                    --tx otg2 --rx otg1 \
  > otg.yml
  ```
3. Take a look at the content of `otg.yml` you just created. Use [OTG Specification](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/open-traffic-generator/models/master/artifacts/openapi.yaml&nocors) as a reference. Note, although we used `otgen` tool to create the file, this could be done in a variety of different ways. See more [here](https://otg.dev/clients/).

## Run OTG testing

1. Run traffic test between emulated devices using test IPs

  ```Shell
  cat otg.yml | \
  otgen run --insecure --api $OTG_API \
            --metrics flow | \
  otgen transform --metrics flow |
  otgen display --mode table
  ```

TODO note this would fail w/o adding static routes. Add those and then the test passes

## Cleanup


1. Destroy the topology

  ```Shell
  sudo -E clab des -t nanog_clab_otg_202210.yml -c
  ```
