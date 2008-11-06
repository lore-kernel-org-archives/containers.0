From: vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Subject: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Thu, 06 Nov 2008 10:30:22 -0500
Message-ID: <20081106153022.215696930__23280.9326881126$1225986502$gmane$org@redhat.com>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Hirokazu Takahashi <taka-jCdQPDEk3ieIwRZHo2/mJg@public.gmane.org>
Cc: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

If you are not already tired of so many io controller implementations, here
is another one.

This is a very eary very crude implementation to get early feedback to see
if this approach makes any sense or not.

This controller is a proportional weight IO controller primarily
based on/inspired by dm-ioband. One of the things I personally found little
odd about dm-ioband was need of a dm-ioband device for every device we want
to control.  I thought that probably we can make this control per request
queue and get rid of device mapper driver. This should make configuration
aspect easy.

I have picked up quite some amount of code from dm-ioband especially for
biocgroup implementation.

I have done very basic testing and that is running 2-3 dd commands in different
cgroups on x86_64. Wanted to throw out the code early to get some feedback.

More details about the design and how to are in documentation patch.

Your comments are welcome.

Thanks
Vivek

-- 
