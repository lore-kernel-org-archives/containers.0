From: Krister Johansen <kjlx-6woCzk5+qv5TrMCiz+cRkdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v4 3/3] Make core_pattern support namespace
Date: Tue, 25 Oct 2016 17:19:38 -0700
Message-ID: <20161026001938.GB2525@templeofstupid.com>
References: <1477380536-3307-1-git-send-email-caosf.fnst@cn.fujitsu.com>
	<1477380536-3307-4-git-send-email-caosf.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1477380536-3307-4-git-send-email-caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cao Shufeng <caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mashimiao.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Oct 25, 2016 at 03:28:56PM +0800, Cao Shufeng wrote:
> From: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> It will bring us following benefit:
> 1: Each container can change their own coredump setting
>    based on operation on /proc/sys/kernel/core_pattern
> 2: Coredump setting changed in host will not affect
>    running containers.
> 3: Support both case of "putting coredump in guest" and
>    "putting curedump in host".

Would you explain more about case #3 here?  In particular, I'm curious
what the impact is for systems that have already configured core_pattern
with the understanding that the program might be invoked to handle
either a host or a container core.  In particular, is there any way to
specify that the container handler fall back to the host handler?

On the systems that I've configured, /proc/sys is mounted read-only in the
container.  The host has a special program run from core_pattern that
determines which container generated the core.  It then stores the cores
in a directory that uniquely identifies the container.  The cores are
isolated on their own filesystem, and given a quota per-container.  The
eventual goal is to have a service evacuate the cores to an object store
where we can make them available to the customer via a web service.

Does your change still allow a global handler in the host to process
cores from containers?  Or is that behavior removed completely?

-K
