"use strict";

const aws = require("@pulumi/aws");
const fs = require('fs');

let size = "t2.micro";     // t2.micro is available in the AWS free tier
let ami = aws.getAmi({
    filters: [{
      name: "name",
      values: ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server*"],
    }],
    owners: ["099720109477"],
    mostRecent: true,
});

let group = new aws.ec2.SecurityGroup("nagios-to.monitor-pulumi", {
    ingress: [
        { protocol: "tcp", fromPort: 22, toPort: 22, cidrBlocks: ["0.0.0.0/0"] },
        { protocol: "tcp", fromPort: 80, toPort: 80, cidrBlocks: ["0.0.0.0/0"] },
    ],
    egress: [
        { protocol: "-1", fromPort: 0, toPort: 0, cidrBlocks: ["0.0.0.0/0"] },
    ],
});

const deployer = new aws.ec2.KeyPair("nagios-test", {
    publicKey: fs.readFileSync('../../../../Creds/nagios-test.pub', 'utf8'),
});

let data = fs.readFileSync('../init.sh', 'utf8');

let server = new aws.ec2.Instance("webserver-www", {
    instanceType: size,
    securityGroups: [ group.name ], // reference the security group resource above
    ami: ami.id,
    keyName: deployer,
    userData: data,
    tags: {
        Name: "Nagios-w-pulumi",
    },
});

exports.publicIp = server.publicIp;
exports.publicHostName = server.publicDns;