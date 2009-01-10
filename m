From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroups: consolidate cgroup documents
Date: Fri, 9 Jan 2009 16:25:02 -0800
Message-ID: <6599ad830901091625h7eb9d978v61f99d4afde220a1@mail.gmail.com>
References: <4966B383.3030106@cn.fujitsu.com>
	<20090109223442.GO9737@balbir.in.ibm.com>
	<20090109161947.70f6d73d.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090109161947.70f6d73d.rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Jan 9, 2009 at 4:19 PM, Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org> wrote:
>
> I'm for that also, but I thought that cpusets existed regardless of
> cgroups/controllers.  Maybe I'm wrong?
>

Cpusets is just a client subsystem of cgroups.

Paul
