#cloud-config
packages:
  - jre
runcmd:
  - mkdir /tmp/oci
  - wget -q -P /tmp/oci http://www.dominicgiles.com/swingbench/swingbenchlatest.zip
  - wget -q -P /tmp/oci http://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient19.5-basic-19.5.0.0.0-1.x86_64.rpm
  - wget -q -P /tmp/oci http://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient19.5-tools-19.5.0.0.0-1.x86_64.rpm
  - wget -q -P /tmp/oci http://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient19.5-sqlplus-19.5.0.0.0-1.x86_64.rpm 
  - wget -q -P /tmp/oci http://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient19.5-jdbc-19.5.0.0.0-1.x86_64.rpm
  - sudo yum install -y /tmp/oci/*.rpm
