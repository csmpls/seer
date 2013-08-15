public class Detector extends Thread {

	// timer elements
	private boolean running;
	private int wait;
	private int count;

	int enter_foc_num_peaks = 40;
	int enter_foc_peak_thresh = 60; // counts as peak when attn OVER this number
	float enter_foc_time = 45; // in seconds

	int leave_foc_num_peaks = 45;
	int leave_foc_peak_thresh = 36; // counts as peak when attn UNDER this number
	float leave_foc_time = 45; // in seconds

	int peaks = 0;

	boolean focus_mode = false;

	Detector() {

		running=false;
		wait=250;
		count=0;

	}

	void start() {

		running=true;
		super.start();
		
	}

	void run() {
	
		while (running) {

			count++;

			if (!focus_mode) {

				if (count > enter_foc_time*4) {
					peaks--;
					count=0;
				}

				if (neurosky.attn > enter_foc_peak_thresh)
					peaks++; 

				if (peaks > enter_foc_num_peaks) {
					focus_mode = true;
					peaks=0;
					count=0;

					//play a sound to indicate entering focus
					enter_foc_chime.trigger();
				}

			} else if (focus_mode) {

				if (count > leave_foc_time*4) {
					peaks--;
					count=0;
				}

				if (neurosky.attn < leave_foc_peak_thresh)
					peaks++; 

				if (peaks > leave_foc_num_peaks) {
					focus_mode = false;
					peaks=0;
					count=0;

					//play  a sound to indicate dropping from focus
					leave_foc_chime.trigger();
				}

			}

			peaks = constrain(peaks,0,999);

			
			//wait for interval
			try { 
				sleep((long)(wait));
			} 
			catch (Exception e) {}
		}
}

	boolean focus_detected() {
		return focus_mode;
	}

}