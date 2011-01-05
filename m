From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: Containers and /proc/sys/vm/drop_caches
Date: Wed, 05 Jan 2011 10:49:55 +0100
Message-ID: <4D243EC3.1050101@free.fr>
References: <20110105094022.GA5366@glandium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110105094022.GA5366-YmoObPS1fuhg9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mike Hommey <mh-YmoObPS1fuhg9hUCZPvPmw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 01/05/2011 10:40 AM, Mike Hommey wrote:
> [Copy/pasted from a previous message to lkml, where it was suggested to
>   try containers@]
>
> Hi,
>
> I noticed that from within a lxc container, writing "3" to
> /proc/sys/vm/drop_caches would flush the host page cache. That sounds a
> little dangerous for VPS offerings that would be based on lxc, as in one
> VPS instance root user could impact the overall performance of the host.
> I don't know about other containers but I've been told openvz isn't
> subject to this problem.
> I only tested the current Debian Squeeze kernel, which is based on
> 2.6.32.27.

There is definitively a big work to do with /proc.

Some files should be not accessible (/proc/sys/vm/drop_caches, 
/proc/sys/kernel/sysrq, ...) and some other should be virtualized 
(/proc/meminfo, /proc/cpuinfo, ...).

Serge suggested to create something similar to the cgroup device 
whitelist but for /proc, maybe it is a good approach for denying access 
a specific proc's file.
