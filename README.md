## Configuring Multiple HTTP Servers

There isn't much to be shared here, hence a lack of proper structure. However, :

1 if you've resources or data providers that are dependent on other resources, run "terraform apply" on those variables first before doing a general terraform apply. reason is if you don't, your infrastructure will encounter errors during setup as terraform will detect errors.