cluster_name                   = "tooling-app-eks"
iac_environment_tag            = "development"
name_prefix                    = "dapetoo-io-eks"
main_network_block             = "10.0.0.0/16"
subnet_prefix_extension        = 4
zone_offset                    = 8
admin_users                    = ["Administrator"]
developer_users                = ["Administrator"]
asg_instance_types             = [{ instance_type = "t3.small" }, { instance_type = "t2.small" }, ]
autoscaling_minimum_size_by_az = 1
autoscaling_maximum_size_by_az = 5
autoscaling_average_cpu        = 30