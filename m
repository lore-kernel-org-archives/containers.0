From: Rishikesh K Rajak <risrajak@in.ibm.com>
Subject: Re: [Devel] LTP result output for container-init ( failure with 2.6.24
 kernel )
Date: Tue, 29 Jan 2008 21:42:42 +0530
Message-ID: <OFDB71F099.8DF97877-ON652573DF.00581FA6-652573DF.00591A31@in.ibm.com>
References: <1200497268.3999.17.camel@localhost.localdomain> <47986165.4050407@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765643AbYA2QN4@vger.kernel.org>
In-Reply-To: <47986165.4050407@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>, vgusev@openvz.org
Cc: balbir@linux.vnet.ibm.com, containers@lists.osdl.org, Poornima Nayak <Poornima.Nayak@in.ibm.com>, serue@linux.vnet.ibm.com, sukadev@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org



Hi Pavel/Vitaliy,

Pavel Emelyanov <xemul@openvz.org> wrote on 01/24/2008 03:29:01 PM:

> Rishikesh K. Rajak wrote:
> > Hi All,
> >
> > Today i ran full LTP on kernel 2.6.24-rc6 inside container-init and
also
> > on parent namespace and got some observations.
> >
> > Here is the machine information:
> >     Linux rishi.in.ibm.com 2.6.18-53.el5 #1 SMP Wed Oct 10 16:34:02 EDT
> > 2007 i686 i686 i386 GNU/Linux
> >
> >     OS: SLES 10
> >
> > I found these fcntl are failing inside container and it pass on parent
> > namespace. I am attaching the log file with this mail.
> >
> > These failures are conceding with 2.6.23-mm1 itself. Just wanted to
know
> > if someone is working on this still.
> >
> >   fcntl11                        FAIL
> >   fcntl14                        FAIL
> >   fcntl17                        FAIL
> >   fcntl19                        FAIL
> >   fcntl20                        FAIL
> >   fcntl21                        FAIL

Today, I tested 2.6.24 kernel and ran LTP inside container, and found that
the above failure is still existing.
These failures are not occuring when i run LTP in parent namespace.

>
> As I already said, these are fixed in -mm tree with the
> pid-namespaces-vs-locks-interaction.patch patch.

I verified, the above patch is still not applied with 2.6.24 kernel.

Parden me ! if i have missed some earlier mail thread.

But one good thing, no syslog failure :)

Thanks
Rishi
>
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
>
> What really bothers me in this case is that in the "output"
> file you attached I see
>
> <<<test_output>>>
> syslog08    0  INFO  :   Test all the facilities at a particular level.
> syslog08    0  INFO  :   Facilities available are: LOG_KERN,
> LOG_USER, LOG_MAIL
> syslog08    0  INFO  :   LOG_DAEMON, LOG_AUTH, LOG_LPR.
> syslog08    0  INFO  :   Don't know how to send kernel messages from
syslog()
> syslog08    0  INFO  :   o Create seperate entries in config file
> for each facility.
> syslog08    0  INFO  :   o Send the message and grep for the entry
> in log file.
>
> syslog08    0  INFO  :  syslog: Testing all the facilities
>
> syslog08    0  INFO  :  Doing facility: user...
> syslog08    0  INFO  :  Restart /etc/init.d/syslog
> syslog08    0  INFO  :   Facility user passed
> syslog08    0  INFO  :  Doing facility: mail...
> syslog08    0  INFO  :  Restart /etc/init.d/syslog
> syslog08    0  INFO  :   Facility mail failed
> syslog08    0  INFO  :  Doing facility: daemon...
> syslog08    0  INFO  :  Restart /etc/init.d/syslog
> syslog08    0  INFO  :   Facility daemon passed
> syslog08    0  INFO  :  Doing facility: auth...
> syslog08    0  INFO  :  Restart /etc/init.d/syslog
> syslog08    0  INFO  :   Facility auth passed
> syslog08    0  INFO  :  Doing facility: lpr...
> syslog08    0  INFO  :  Restart /etc/init.d/syslog
> syslog08    0  INFO  :   Facility lpr passed
> syslog08    1  PASS  :  some facilities failed to work
> syslog08    0  INFO  :  restart /etc/init.d/syslog
>
> The says it passed, but the status is "some facilities failed to
> work" and the log file says that the test failed %)
>
> I launched ltp on my box but the 01, 02 and 08 syslog tests
> passed... I have a CentOS 4 setup on this node, maybe this
> is a SuSE issue? Rishikesh, can you try this on another OS?
>
> > Please let me know your opinion on this.
> >
> > Thanks
> >
> > Rishi
> > IBM LTC
> > Bangalore
> >
> >
> >
> >
------------------------------------------------------------------------
> >
> > _______________________________________________
> > Containers mailing list
> > Containers@lists.linux-foundation.org
> > https://lists.linux-foundation.org/mailman/listinfo/containers
> >
> >
> >
------------------------------------------------------------------------
> >
> > _______________________________________________
> > Devel mailing list
> > Devel@openvz.org
> > https://openvz.org/mailman/listinfo/devel
>
