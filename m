From: Sergey Kononenko <sergk-Xso+ZjpL9WJWk0Htik3J/w@public.gmane.org>
Subject: Re: Restriction of filesystem mounting
Date: Wed, 16 Sep 2009 00:15:08 +0300
Message-ID: <20090916001508.7526e0ba@vingilot.sergknet>
References: <20090915233527.3c0129ed@vingilot.sergknet>
	<1253047360.10449.11671.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253047360.10449.11671.camel@nimitz>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

> Could you explain a little more why you have this requirement?
> Anybody in their own filesystem namespace can do no harm to users in
> other namespaces.  What's the worry?
I don't want to expose information about hardware configuration to
processes inside container which now can be easily accessed by mounting
sysfs. Also through sysfs direct access to hardware is possible and
that definitely can do harm to other containers and whole system. For
example removing hard drives by
echo 1 > /sys/bus/scsi/drivers/sd/<SCSI-ID>/delete
So I definitely want to forbid mounting of sysfs inside container.
And probably there are some other "dangerous" filesystems.

Also in the future I plan to make mount option for proc filesystem
which hide kernel low level or hardware information
(/proc/bus, /proc/interrupts, etc.) And I want to mount proc with such
option inside container once, without possibility of remounting
without option and getting unrestricted view of proc.

With best regards,
Sergey Kononenko.
