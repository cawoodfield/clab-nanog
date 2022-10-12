# NANOG Hackathon Containerlab Setup

## Deployment

1. Clone this reposotory to `/opt` as:

```Shell
sudo git clone https://github.com/bortok/clab-nanog.git /opt/clab
```

2. Add cRPD license file to `/opt/clab/files/junos_sfnt.lic`

3. Pull Docker images for Arista cEOSLab and Juniper cRPD and tag them as `ceos:latest` and `crpd:latest` respectively

4. Deploy the lab using

```Shell
cd /opt/clab
sudo -E clab dep -t nanog_clab.yaml
```

## Cleanup

1. Destroy the lab using

```Shell
cd /opt/clab
sudo -E clab des -t nanog_clab.yaml -c
```

