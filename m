From: "Rishikesh K. Rajak" <risrajak-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: LTP result output for container-init
Date: Wed, 16 Jan 2008 22:09:46 +0530
Message-ID: <1200501586.3999.38.camel@localhost.localdomain>
References: <1200497268.3999.17.camel@localhost.localdomain>
	<20080116160709.GA8716@balbir.in.ibm.com>
Reply-To: risrajak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2014210987=="
Return-path: <ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20080116160709.GA8716-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ltp-list>,
	<mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ltp-list>
List-Post: <mailto:ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ltp-list>,
	<mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: Poornima.Nayak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, risrajak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, serue-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org


--===============2014210987==
Content-Type: multipart/alternative; boundary="=-Qx9d+Zb2RBkwJxWtpGep"


--=-Qx9d+Zb2RBkwJxWtpGep
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2008-01-16 at 21:37 +0530, Balbir Singh wrote:

> * Rishikesh K. Rajak <risrajak-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> [2008-01-16 20:57:48]:
> 
> Hi, Rishi,
> 
> > Hi All,
> > 
> > Today i ran full LTP on kernel 2.6.24-rc6 inside container-init and also
> > on parent namespace and got some observations.
> > 
> > Here is the machine information:
> >     Linux rishi.in.ibm.com 2.6.18-53.el5 #1 SMP Wed Oct 10 16:34:02 EDT
> > 2007 i686 i686 i386 GNU/Linux
> > 
> >     OS: SLES 10
> > 
> 
> Are you sure? Looks like this is a RHEL5 kernel (from your uname)

Yeah, something interesting, but It's true it is SUSE.

:~/rishi/result # cat /etc/issue
    Welcome to SUSE Linux Enterprise Server 10 SP2 Alpha2 (i586) -
Kernel \r (\l).

> 
> > I found these fcntl are failing inside container and it pass on parent
> > namespace. I am attaching the log file with this mail.
> > 
> > These failures are conceding with 2.6.23-mm1 itself. Just wanted to know
> 
> What do you mean by conceding with 2.6.23-mm1?

This means i have reported this problem earlier also to concern
developer and i have heard that it is already a known problem for pidns.
So just wanted to know if it is being fix by someone.


> 
> > if someone is working on this still.
> 
> LTP mailing list would be a better place to ask


Yes CC'ing to ltp-list@ also.

> 
> > 
> >   fcntl11                        FAIL
> >   fcntl14                        FAIL
> >   fcntl17                        FAIL
> >   fcntl19                        FAIL
> >   fcntl20                        FAIL
> >   fcntl21                        FAIL
> > 
> > And also other observation was:
> > 
> > syslog is failing inside parent namespace but pass inside
> > container-init.
> > 
> > syslog01                       FAIL
> > 1                                        
> > syslog02                       FAIL
> > 1                                        
> > syslog08                       FAIL
> > 1                                        
> > 
> > Please let me know your opinion on this.
> > 
> 
> These are good results, but analysis of the results will be very
> useful. For example
> 
> 1. You could list the diff with a LTP run in parent namespace vs
>    within the container
> 2. diff b/w LTP run in parent namespace vs a kernel without containers
>    enabled (this would obviously imply that the containers test cases
>    won't run)
> 


First case has already been taken care and i provided the attached
result. The mail text is diff of LTP result between parent namespace Vs
container-init.

Yes second case sounds good, result can be expected soon for this,
thanks balbir.

Rishi

> You could then try and get to the root cause of the failure(s) and
> report them.
> 
> It would be useful to post the same results to the LTP mailing list
> and I 
> 

--=-Qx9d+Zb2RBkwJxWtpGep
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 TRANSITIONAL//EN">
<HTML>
<HEAD>
  <META HTTP-EQUIV="Content-Type" CONTENT="text/html; CHARSET=UTF-8">
  <META NAME="GENERATOR" CONTENT="GtkHTML/3.12.0">
</HEAD>
<BODY>
On Wed, 2008-01-16 at 21:37 +0530, Balbir Singh wrote:
<BLOCKQUOTE TYPE=CITE>
<PRE>
<FONT COLOR="#000000">* Rishikesh K. Rajak &lt;<A HREF="mailto:risrajak-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org">risrajak-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org</A>&gt; [2008-01-16 20:57:48]:</FONT>

<FONT COLOR="#000000">Hi, Rishi,</FONT>

<FONT COLOR="#000000">&gt; Hi All,</FONT>
<FONT COLOR="#000000">&gt; </FONT>
<FONT COLOR="#000000">&gt; Today i ran full LTP on kernel 2.6.24-rc6 inside container-init and also</FONT>
<FONT COLOR="#000000">&gt; on parent namespace and got some observations.</FONT>
<FONT COLOR="#000000">&gt; </FONT>
<FONT COLOR="#000000">&gt; Here is the machine information:</FONT>
<FONT COLOR="#000000">&gt;     Linux rishi.in.ibm.com 2.6.18-53.el5 #1 SMP Wed Oct 10 16:34:02 EDT</FONT>
<FONT COLOR="#000000">&gt; 2007 i686 i686 i386 GNU/Linux</FONT>
<FONT COLOR="#000000">&gt; </FONT>
<FONT COLOR="#000000">&gt;     OS: SLES 10</FONT>
<FONT COLOR="#000000">&gt; </FONT>

<FONT COLOR="#000000">Are you sure? Looks like this is a RHEL5 kernel (from your uname)</FONT>
</PRE>
</BLOCKQUOTE>
Yeah, something interesting, but It's true it is SUSE.<BR>
<BR>
:~/rishi/result # cat /etc/issue<BR>
&nbsp;&nbsp;&nbsp; Welcome to SUSE Linux Enterprise Server 10 SP2 Alpha2 (i586) - Kernel \r (\l).
<BLOCKQUOTE TYPE=CITE>
<PRE>

<FONT COLOR="#000000">&gt; I found these fcntl are failing inside container and it pass on parent</FONT>
<FONT COLOR="#000000">&gt; namespace. I am attaching the log file with this mail.</FONT>
<FONT COLOR="#000000">&gt; </FONT>
<FONT COLOR="#000000">&gt; These failures are conceding with 2.6.23-mm1 itself. Just wanted to know</FONT>

<FONT COLOR="#000000">What do you mean by conceding with 2.6.23-mm1?</FONT>
</PRE>
</BLOCKQUOTE>
This means i have reported this problem earlier also to concern developer and i have heard that it is already a known problem for pidns. So just wanted to know if it is being fix by someone.<BR>
<BR>
<BLOCKQUOTE TYPE=CITE>
<PRE>

<FONT COLOR="#000000">&gt; if someone is working on this still.</FONT>

<FONT COLOR="#000000">LTP mailing list would be a better place to ask</FONT>
</PRE>
</BLOCKQUOTE>
<BR>
Yes CC'ing to ltp-list@ also.
<BLOCKQUOTE TYPE=CITE>
<PRE>

<FONT COLOR="#000000">&gt; </FONT>
<FONT COLOR="#000000">&gt;   fcntl11                        FAIL</FONT>
<FONT COLOR="#000000">&gt;   fcntl14                        FAIL</FONT>
<FONT COLOR="#000000">&gt;   fcntl17                        FAIL</FONT>
<FONT COLOR="#000000">&gt;   fcntl19                        FAIL</FONT>
<FONT COLOR="#000000">&gt;   fcntl20                        FAIL</FONT>
<FONT COLOR="#000000">&gt;   fcntl21                        FAIL</FONT>
<FONT COLOR="#000000">&gt; </FONT>
<FONT COLOR="#000000">&gt; And also other observation was:</FONT>
<FONT COLOR="#000000">&gt; </FONT>
<FONT COLOR="#000000">&gt; syslog is failing inside parent namespace but pass inside</FONT>
<FONT COLOR="#000000">&gt; container-init.</FONT>
<FONT COLOR="#000000">&gt; </FONT>
<FONT COLOR="#000000">&gt; syslog01                       FAIL</FONT>
<FONT COLOR="#000000">&gt; 1                                        </FONT>
<FONT COLOR="#000000">&gt; syslog02                       FAIL</FONT>
<FONT COLOR="#000000">&gt; 1                                        </FONT>
<FONT COLOR="#000000">&gt; syslog08                       FAIL</FONT>
<FONT COLOR="#000000">&gt; 1                                        </FONT>
<FONT COLOR="#000000">&gt; </FONT>
<FONT COLOR="#000000">&gt; Please let me know your opinion on this.</FONT>
<FONT COLOR="#000000">&gt; </FONT>

<FONT COLOR="#000000">These are good results, but analysis of the results will be very</FONT>
<FONT COLOR="#000000">useful. For example</FONT>

<FONT COLOR="#000000">1. You could list the diff with a LTP run in parent namespace vs</FONT>
<FONT COLOR="#000000">   within the container</FONT>
<FONT COLOR="#000000">2. diff b/w LTP run in parent namespace vs a kernel without containers</FONT>
<FONT COLOR="#000000">   enabled (this would obviously imply that the containers test cases</FONT>
<FONT COLOR="#000000">   won't run)</FONT>

</PRE>
</BLOCKQUOTE>
<BR>
First case has already been taken care and i provided the attached result. The mail text is diff of LTP result between parent namespace Vs container-init.<BR>
<BR>
Yes second case sounds good, result can be expected soon for this, thanks balbir.<BR>
<BR>
Rishi
<BLOCKQUOTE TYPE=CITE>
<PRE>
<FONT COLOR="#000000">You could then try and get to the root cause of the failure(s) and</FONT>
<FONT COLOR="#000000">report them.</FONT>

<FONT COLOR="#000000">It would be useful to post the same results to the LTP mailing list</FONT>
<FONT COLOR="#000000">and I </FONT>

</PRE>
</BLOCKQUOTE>
</BODY>
</HTML>

--=-Qx9d+Zb2RBkwJxWtpGep--



--===============2014210987==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============2014210987==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Ltp-list mailing list
Ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/ltp-list

--===============2014210987==--
