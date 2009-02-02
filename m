From: "Chris Friesen" <cfriesen-ZIRUuHA3oDzQT0dZR+AlfA@public.gmane.org>
Subject: Re: cgroup mount point
Date: Mon, 02 Feb 2009 16:54:58 -0600
Message-ID: <498779C2.2060908__27194.9574504562$1233615461$gmane$org@nortel.com>
References: <20090202200013.GU3643@vespa.holoscopio.com>
	<1233606371.15779.32.camel@radis.liafa.jussieu.fr>
	<20090202205246.GA28593@glandium.org>
	<20090202214153.GV3643@vespa.holoscopio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090202214153.GV3643-StA3NKSgq9XYLCA8tIpKU1aTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Thadeu Lima de Souza Cascardo <cascardo-/wxwWNsM9nk+uJoB2kUjGw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, debian-devel-0aAXYlwwYIJuHlm7Suoebg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Thadeu Lima de Souza Cascardo wrote:

> Linux Documentation is not consistent and have some funny options. In
> Documentation/cgroups/*, we have:

> So, we have some more options now: /cgroups, /containers, /dev/cpuset,
> /dev/cpuctl, /opt/cgroup, /opt/cpuset.
> 
> I am copying the container and the kernel guys. Perhaps, we can find an
> agreement (if we want to find one at all) and change all that
> Documentation to get consistent.

I'd vote for "cgroups" or "containers", mounted at / or /sys/.

/opt feels more like where software should live, and /dev should be for 
devices rather than capabilities/management.  "cpuctl" and "cpuset" are 
subsets of the full capabilities of cgroups, so they're suboptimal as 
far as naming.

Chris
