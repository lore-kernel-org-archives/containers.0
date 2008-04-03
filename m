From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][patch 3/11][CFQ-cgroup] Introduce cgroup subsystem
Date: Thu, 3 Apr 2008 08:31:25 -0700
Message-ID: <6599ad830804030831h12cac799ub4e1c9a169c722da__44238.6794057258$1207236972$gmane$org@mail.gmail.com>
References: <007801c893d9$d89726f0$89c574d0$@jp.nec.com>
	<008001c893db$4e2eccf0$ea8c66d0$@jp.nec.com>
	<6599ad830804021541s3c1e3197y77d87f63bf47e4b3@mail.gmail.com>
	<003001c89532$dae5dd20$90b19760$@jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <003001c89532$dae5dd20$90b19760$@jp.nec.com>
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
To: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, tom-sugawara-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Apr 2, 2008 at 7:31 PM, Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org> wrote:
>  >
>  > What are these checks for? Cgroups already provides filesystem
>  > permissions to control directory creation, and the "descendant" check
>  > looks like it may have been cut/pasted from the nsproxy subsystem.
>  >
>
>  This code was referred one of io-throttle.
>  Is it not necessary these checks?
>  IF not necessary, remove this code.
>

Yes, I think these checks should be removed. Especially the descendant check.

Paul
