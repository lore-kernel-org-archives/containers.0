From: Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>
Subject: Re: checkpoint/restart ABI
Date: Tue, 12 Aug 2008 10:04:57 -0700
Message-ID: <48A1C2B9.9070107__28976.6759182841$1218560929$gmane$org@goop.org>
References: <20080807224033.FFB3A2C1@kernel>	
	<200808090013.41999.arnd@arndb.de>
	<20080811152201.GB25930@us.ibm.com>	
	<200808111853.13854.arnd@arndb.de>
	<1218484114.5598.43.camel@nimitz>	 <48A0CD86.6030704@goop.org>
	<1218553091.5598.76.camel@nimitz>	 <48A1BB39.3090108@goop.org>
	<1218559619.5598.97.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1218559619.5598.97.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Daniel Lezcano <daniel.lezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Peter Chubb <peterc-M3ycANVxPotyL3EAZA59ERCuuivNXqWP@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
>>> I'm not sure what you mean by "closed files".  Either the app has a fd,
>>> it doesn't, or it is in sys_open() somewhere.  We have to get the app
>>> into a quiescent state before we can checkpoint, so we basically just
>>> say that we won't checkpoint things that are *in* the kernel.
>>>       
>> It's common for an app to write a tmp file, close it, and then open it a 
>> bit later expecting to find the content it just wrote.  If you 
>> checkpoint-kill it in the interim, reboot (clearing out /tmp) and then 
>> resume, then it will lose its tmp file.  There's no explicit connection 
>> between the process and its potential working set of files.
>>     
>
> I respectfully disagree.  The number one prerequisite for
> checkpoint/restart is isolation.  Xen just happens to get this for free.
>   

(I don't have my Xen hat on at all for this thread.)

> So, instead of saying that there's no explicit connection between the
> process and its working set, ask yourself how we make a connection.
>
> In this case, we can do it with a filesystem (mount) namespace.  Each
> container that we might want to checkpoint must have its writable
> filesystems contained to a private set that are not shared with other
> containers.  Things like union mounts would help here, but aren't
> necessarily required.  They just make it more efficient.
>   

We were dealing with checkpointing random sets of processes, and that 
posed all sorts of problems.  Filesystem namespace was one, the pid 
namespace was another.  Doing checkpointing at the container-level 
granularity definitely solves a lot of problems.

>>> Is there anything specific you are thinking of that particularly worries
>>> you?  I could write pages on the list you have there.
>>>       
>> No, that's the problem; it all worries me.  It's a big problem space.
>>     
>
> It's almost as big of a problem as trying to virtualize entire machines
> and expecting them to run as fast as native. :)
>   

No, it's much harder.  Hardware is relatively simple and immutable 
compared to kernel and process state ;)

> Cool!  I didn't know you guys did the IRIX implementation.  I'm sure you
> guys got a lot farther than any of us are.  Did you guys ever write any
> papers or anything on it?  I'd be interested in more information.
>   

Yeah, there was a paper, but it looks like the internet has lost it.  It 
was at 
http://www.csu.edu.au/special/conference/apwww95/.papers95/cmaltby/cmaltby.ps
http://www.csu.edu.au/special/conference/apwww95/sept-all.html has 
mention of the paper.

    J
