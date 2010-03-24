From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 5/5][lxc] Hook up lxc_checkpoint() with app_checkpoint()
Date: Wed, 24 Mar 2010 12:35:37 -0700
Message-ID: <20100324193537.GB20031@us.ibm.com>
References: <20100319063912.GA25732@us.ibm.com>
	<20100319064141.GF25732@us.ibm.com> <4BA78262.6050109@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BA78262.6050109-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Daniel Lezcano [dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org] wrote:
>> +find_cinit_pid(const char *name)
>>  {
>> +	struct lxc_command command = {
>> +		.request = { .type = LXC_COMMAND_CINIT_PID },
>> +	};
>> +
>> +	int ret, stopped;
>> +
>> +	ret = lxc_command(name, &command, &stopped);
>> +	if (ret < 0) {
>> +		ERROR("failed to send command");
>> +		return -1;
>> +	}
>> +
>> +	ERROR("find_cinit_pid %d\n", command.answer.ret);
>> +
>> +	return command.answer.ret;
>> +}
>
> I just committed the same function for the lxc_attach command. I think  
> you can reuse it.

Ok, will try to reuse it.

>
>> +int lxc_checkpoint(const char *name, const char *statefile, int lxc_flags)
>> +{
>> +	int ret;
>> +	int pid;
>> +	int flags;
>> +	struct stat statbuf;
>> +	struct app_checkpoint_args crargs;
>> +
>> +	if (access(statefile, F_OK) == 0) {
>> +		ret = stat(statefile, &statbuf);
>> +		if (ret < 0) {
>> +			ERROR("stat(%s): %s\n", statefile, strerror(errno));
>> +			return -1;
>> +		}
>> +
>> +		if (S_ISDIR(statbuf.st_mode)) {
>> +			ERROR("--directory option not implemented");
>> +			return -1;
>> +		} else {
>> +			ERROR("Checkpoint image file %s exists\n", statefile);
>> +			return -1;
>> +		}
>> +	}
>
> For the checkpoint, you don't need to check if it's a directory or a  
> file (but it should be done at restart time).

I need to open() the statefile and pass its fd to app_checkpoint().
If I don't check for directory, the open() below would fail, only
because of the O_RDWR flag. By checking, we could give a more useful
error message ?

> I am not sure 'access' is  
> really necessary because the O_EXCL is set in the open below.

Agree. How about just the stat() and the error message ?

Maybe later we could bury this code under say #ifdef USERCR so
if LXC is configured without USERCR, the current behavior is preserved ?

>
>> +
>> +	pid = find_cinit_pid(name);
>> +	if (pid < 0) {
>> +		ERROR("Unable to find cinit pid");
>> +		return -1;
>> +	}
>> +
>> +	memset(&crargs, 0, sizeof(crargs));
>> +
>> +	ret = open(statefile, O_CREAT|O_RDWR|O_EXCL, 0644);
>> +	if (ret < 0) {
>> +		ERROR("open(%s) failed\n", statefile);
>> +		return -1;
>> +	}
>
> As the statefile may contain sensible data, it would be preferable to  
> set it 0600, no ?

Agree.
