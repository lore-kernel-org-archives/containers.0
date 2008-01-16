From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: LTP result output for container-init
Date: Wed, 16 Jan 2008 21:37:09 +0530
Message-ID: <20080116160709.GA8716@balbir.in.ibm.com>
References: <1200497268.3999.17.camel@localhost.localdomain>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1200497268.3999.17.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: risrajak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org
Cc: Poornima.Nayak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, serue-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

* Rishikesh K. Rajak <risrajak-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> [2008-01-16 20:57:48]:

Hi, Rishi,

> Hi All,
> 
> Today i ran full LTP on kernel 2.6.24-rc6 inside container-init and also
> on parent namespace and got some observations.
> 
> Here is the machine information:
>     Linux rishi.in.ibm.com 2.6.18-53.el5 #1 SMP Wed Oct 10 16:34:02 EDT
> 2007 i686 i686 i386 GNU/Linux
> 
>     OS: SLES 10
> 

Are you sure? Looks like this is a RHEL5 kernel (from your uname)

> I found these fcntl are failing inside container and it pass on parent
> namespace. I am attaching the log file with this mail.
> 
> These failures are conceding with 2.6.23-mm1 itself. Just wanted to know

What do you mean by conceding with 2.6.23-mm1?

> if someone is working on this still.

LTP mailing list would be a better place to ask

> 
>   fcntl11                        FAIL
>   fcntl14                        FAIL
>   fcntl17                        FAIL
>   fcntl19                        FAIL
>   fcntl20                        FAIL
>   fcntl21                        FAIL
> 
> And also other observation was:
> 
> syslog is failing inside parent namespace but pass inside
> container-init.
> 
> syslog01                       FAIL
> 1                                        
> syslog02                       FAIL
> 1                                        
> syslog08                       FAIL
> 1                                        
> 
> Please let me know your opinion on this.
> 

These are good results, but analysis of the results will be very
useful. For example

1. You could list the diff with a LTP run in parent namespace vs
   within the container
2. diff b/w LTP run in parent namespace vs a kernel without containers
   enabled (this would obviously imply that the containers test cases
   won't run)

You could then try and get to the root cause of the failure(s) and
report them.

It would be useful to post the same results to the LTP mailing list
and I 

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
