variable "cidr_block_PUBSUB1"{
    description = "This is the cidr_block for our public subnet"
    type = string
    default = " 10.0.0.0/24"
}

variable "AZ1"{
    description = "This is the AZ for our public subnet"
    type = string
    default = "eu-west-2a"
}

variable "ami"{
    description = "This is the Ami for our instance"
    type = string
    default = "ami-084e8c05825742534"
}

variable "instance_type"{
    description = "This is instance_type for our instance"
    type = string
    default = "t2.micro"
}
