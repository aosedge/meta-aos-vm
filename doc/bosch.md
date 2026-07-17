# Bosch demo

The following steps should be performed to deploy Bosch demo services on Aos VM:

1. Start Bosch demo VM and provision the unit:
   https://github.com/aosedge/meta-aos-vm/releases/download/v6.1.0-bosch.1/aos-vm-image-genericx86-64-6.1.1-bosch.1.tar.xz

2. Deploy the unit config to your target:

   * download the unit config for Bosch demo:
     https://github.com/aosedge/meta-aos-vm/blob/demo_bosch/misc/unitconfig.json

   * deploy the init config to the unit:
     https://stage.docs.aosedge.tech/docs/reference/core-component-configs/unit-config

3. Deploy the required Aos layers to the AosCloud:

   * download the require layers:
     https://github.com/aosedge/meta-aos-vm/releases/download/v6.1.1-bosch.1/aos-vm-layers-genericx86-64-6.1.1-bosch.1.tar.gz

   * unpack the layers:

   ```console
   tar -xvf aos-vm-layers-genericx86-64-6.1.1-bosch.1.tar.gz
   ```

   * deploy the layers to the AosCloud:

   ```console
   cd layers
   aos-signer go
   ```

4. Deploy Bosch demo services to the AosCloud:

    * clone demo services repository: https://github.com/aosedge/demo-services.git

    * go to `ev-range-extender` folder and deploy the services:

    ```console
    cd demo-services/ev-range-extender
    aos-signer go
    ```

5. Deploy Bosch demo services to the unit:
   https://stage.docs.aosedge.tech/docs/how-to/run-your-application/

6. Run Bosch demo hardware simulator:

```console
cd demo-services/ev-range-extender/hardware-sim
python3 pytk_dashboard.py
```
