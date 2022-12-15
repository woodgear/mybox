## Howto

### Create Box

You can create box by using  [Packer](https://packer.io).

```
$ packer build ./centos-7-server-x86_64.pkr.hcl
```


### Import box to Vagrant

```
vagrant box add boxes/centos7-server-base.box  --name centos7-server-base:v0.0.1
```