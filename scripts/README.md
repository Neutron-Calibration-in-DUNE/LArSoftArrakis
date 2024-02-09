# Submitting your job

This job has two stages:
  1) Gen stage (this is actually external to larsoft and is intended to produce PNS neutrons in a HEPEvt format
  2) The Simulation, this runs the LArSoft Gen, G4, and finally the Arrakis analyzer module

## 1. Source your setup first.

```
source setup_arrakis.sh
```

## 2. Create your tarball:
```
LARSOFT_VERSION="v09_75_00"
FLAT_QUALS="e20_prof"

tar --exclude '.git' -czf LArSoftArrakis_${LARSOFT_VERSION}.tar.gz ./larsoft/localProducts_larsoft_${LARSOFT_VERSION}_${FLAT_QUALS} ./geometry ./generator ./fcl ./scripts/setup_arrakis.sh
```

## 3. Stablish your credentials, including getting a token

## 4. Run: 
```
bash submit_jobsub_prod_DDGandRads_gen-sim.sh
```

This contains the very long command for jobsub_lite.
You can modify this to change the nubmer of jobs you want to request.
Always test your scripts w/ a few jobs until you are sure that they will work.

## 5. Check the status of your jobs
```
jobsub_q -G dune --user <username>
```

Also you can visualize the status of your jobs in the [FIFE monitor](https://fifemon.fnal.gov/monitor/d/000000053/experiment-batch-details?orgId=1&var-experiment=dune).


More info on how to send jobs in [DUNE tutorials](https://dune.github.io/computing-training-202105/07-grid-job-submission/index.html).
