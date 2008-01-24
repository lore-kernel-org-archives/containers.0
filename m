From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] LTP result output for container-init
Date: Thu, 24 Jan 2008 13:32:30 +0300
Message-ID: <4798693E.5080801@openvz.org>
References: <1200497268.3999.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: Poornima.Nayak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, serue-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Rishikesh K. Rajak wrote:
> Hi All,
> 
> Today i ran full LTP on kernel 2.6.24-rc6 inside container-init and also
> on parent namespace and got some observations.
> 
> Here is the machine information:
>     Linux rishi.in.ibm.com 2.6.18-53.el5 #1 SMP Wed Oct 10 16:34:02 EDT

Wait a bit - this uname string shows the 2.6.18-53.el5 kernel, but
you say, that this was 2.6.24-rc6.

> 2007 i686 i686 i386 GNU/Linux
> 
>     OS: SLES 10
> 
> I found these fcntl are failing inside container and it pass on parent
> namespace. I am attaching the log file with this mail.
> 
> These failures are conceding with 2.6.23-mm1 itself. Just wanted to know
> if someone is working on this still.
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

Have just tested this with SLES10 - syslogs are working...

> Please let me know your opinion on this.
> 
> Thanks
> 
> Rishi
> IBM LTC
> Bangalore
> 
> 
> 
> ------------------------------------------------------------------------
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
> 
> ------------------------------------------------------------------------
> 
> _______________________________________________
> Devel mailing list
> Devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
> https://openvz.org/mailman/listinfo/devel
