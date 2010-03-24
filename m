From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/5][lxc] Hook up lxc_checkpoint() with app_checkpoint()
Date: Wed, 24 Mar 2010 21:51:48 +0100
Message-ID: <4BAA7B64.9080004@fr.ibm.com>
References: <20100319063912.GA25732@us.ibm.com>
	<20100319064141.GF25732@us.ibm.com> <4BA78262.6050109@fr.ibm.com>
	<20100324193537.GB20031@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100324193537.GB20031-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu wrote:
> Daniel Lezcano [dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org] wrote:
>>> +find_cinit_pid(const char *name)
>>>  {
>>> +	struct lxc_command command = {
>>> +		.request = { .type = LXC_COMMAND_CINIT_PID },
>>> +	};
>>> +
>>> +	int ret, stopped;
>>> +
>>> +	ret = lxc_command(name, &command, &stopped);
>>> +	if (ret < 0) {
>>> +		ERROR("failed to send command");
>>> +		return -1;
>>> +	}
>>> +
>>> +	ERROR("find_cinit_pid %d\n", command.answer.ret);
>>> +
>>> +	return command.answer.ret;
>>> +}
>> I just committed the same function for the lxc_attach command. I think  
>> you can reuse it.
> 
> Ok, will try to reuse it.
> 
>>> +int lxc_checkpoint(const char *name, const char *statefile, int lxc_flags)
>>> +{
>>> +	int ret;
>>> +	int pid;
>>> +	int flags;
>>> +	struct stat statbuf;
>>> +	struct app_checkpoint_args crargs;
>>> +
>>> +	if (access(statefile, F_OK) == 0) {
>>> +		ret = stat(statefile, &statbuf);
>>> +		if (ret < 0) {
>>> +			ERROR("stat(%s): %s\n", statefile, strerror(errno));
>>> +			return -1;
>>> +		}
>>> +
>>> +		if (S_ISDIR(statbuf.st_mode)) {
>>> +			ERROR("--directory option not implemented");
>>> +			return -1;
>>> +		} else {
>>> +			ERROR("Checkpoint image file %s exists\n", statefile);
>>> +			return -1;
>>> +		}
>>> +	}
>> For the checkpoint, you don't need to check if it's a directory or a  
>> file (but it should be done at restart time).
> 
> I need to open() the statefile and pass its fd to app_checkpoint().
> If I don't check for directory, the open() below would fail, only
> because of the O_RDWR flag. By checking, we could give a more useful
> error message ?

What I meant is the directory shall not exists when checkpointing, if 
the directory or the file exists, the checkpoint should fail.

>> I am not sure 'access' is  
>> really necessary because the O_EXCL is set in the open below.
> 
> Agree. How about just the stat() and the error message ?

IMO, just fail when trying to open the file, the O_EXCL flag will do the 
job for us.

> Maybe later we could bury this code under say #ifdef USERCR so
> if LXC is configured without USERCR, the current behavior is preserved ?

Right, it's an aspect we have to address. But we can do that later, IMHO 
the main objective would be to correctly integrate lxc and the CR with 
the 'configure' script. eg configure --with-linux=<path> .... and the 
makefiles.
