From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup(fix critical bug): new handling for tasks file
Date: Tue, 26 Aug 2008 15:40:48 -0700
Message-ID: <6599ad830808261540j2b5c46cdsc42e26fa43f3f8d1__42833.5228040398$1219790701$gmane$org@mail.gmail.com>
References: <48B360CE.2010501@cn.fujitsu.com>
	<6599ad830808251929p10dfc9d2ub11e4db0cd4f9f3@mail.gmail.com>
	<48B39319.7070403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48B39319.7070403-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Aug 25, 2008 at 10:22 PM, Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>> But improving the current code has been on my todo list for a while.
>> My thought on the best way to fix it is to use a proper seq_file -
>> that would remove the issues that you have currently with the
>> "unconsumed" portion of the output.
>
> But for my poor knowledge we always have to handle "unconsumed portion"
> for nonseekable file in all different way. In my binary search based
> solving, I have to handle unconsumed part for a pid and bring in
> some complicated. This is really a disadvantage as you pointed out.

I meant that the seq_file code could handle the "unconsumed" portion
for you, rather than you having to manage it explicitly.

Paul
