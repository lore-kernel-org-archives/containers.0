From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: 10K containers
Date: Wed, 02 Sep 2009 15:52:15 -0400
Message-ID: <1251921135.6866.20.camel@dogo.mojatatu.com>
Reply-To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Olla,

Has anybody benchmarked in the range of 10K containers for virtual
routing or even virtual servers with traffic? If you have, could you
share your experience on memory, cpu and throughput?

I have been pointed to:
https://lists.linux-foundation.org/pipermail/containers/2009-January/015315.html

which focuses on creation phase.
Dan, was "slow" measured by how long it took to create? What was the
kernel? I am running  2.6.31-rc7 - do the sysfs issues still exist?

I have also been pointed to:
http://lxc.sourceforge.net/network/benchs.php
Demonstrates throughput - seems to stay constant with the case of etun
hitting  2+ times the CPU use!
I am taking it that etun is pretty close to veth performance-wise, so
the results there may still be valid today.

Daniel - maybe you run these tests; is there a profile that points out
where the bottleneck is?

cheers,
jamal
