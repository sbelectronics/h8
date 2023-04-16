MW_BMEMR_BMEMW_WAIT.jpg
 
  * This illustrates the problem MW has been extended due to wait state, and MEMR hits before MW has completed

MW_MR_BMEMW_WAIT

  * Another view, when I tried to fix this without implementing a delay. Here MR does come after MW, but so close that the op is still lost.


MW_BMEMR_MR_DELAY, MW_BMEMR_MR_DELAY_close

  * This is afterI fixed the problem. You can see Delay causes MR to not assert until well after MW