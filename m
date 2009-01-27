From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Checkpoint / Restart
Date: Tue, 27 Jan 2009 09:59:47 -0600
Message-ID: <20090127155947.GB10039@us.ibm.com>
References: <EF0F4DD0-96C2-47CF-A247-19002A3BD53B@uni-duesseldorf.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <EF0F4DD0-96C2-47CF-A247-19002A3BD53B-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ralph-Gordon Paul <Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Ralph-Gordon Paul (Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org):
> Hello,
> 
> i'm searching for the right Mailing List for Linux checkpoint / restart.
> 
> I'm working for the XtreemOS Project (http://www.xtreemos.eu). We want  
> to include the linux native checkpoint / restart, but it seems to not  
> work. I tested it with the delivered test applications, but they don't  
> work. The restart application (rstr) throws a segmentation fault. I  
> tried both tests from the documentation, checkpointing self and  
> checkpoint from another process. My Architecture is a Pentium D.
> 
> Sorry if this is the wrong Mailing List, i couldn't find the right  
> place (forum or mailing list).
> 
> Thanks for Help,

Hi,

Yup, this is the right list - well either this or lkml.

IIUC you're saying you tested this on a 64-bit x86.  That is
in fact not yet supported.  With Oren's patchset, you can
only use x86_32.  (With the patch I sent last week, you could
also do s390x.)  Support for x86_64 shouldn't take much work -
I think Dave was going to see about such a port, and Oren
may have one at the ready, but you could also do it yourself
if you're so inclined.

-serge
