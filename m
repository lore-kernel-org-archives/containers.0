From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 1/1] templates: don't put devpts in
	$confdir/container/fstab
Date: Sat, 07 May 2011 01:36:35 +0200
Message-ID: <4DC48603.10605@free.fr>
References: <20110506170516.GA20670@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110506170516.GA20670-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 05/06/2011 07:05 PM, Serge E. Hallyn wrote:
> src/lxc/conf.c will explicitly mount it anyway.  Furthermore, the fstab
> entry, which is getting processed first, did not specify -o newinstance.
> This can cause the host's devpts entry mount options to change, as in
> https://bugs.launchpad.net/ubuntu/+source/libvirt/+bug/607636.
>
> I believe the lenny, fedora, and debian templates also will need an
> update.
>
Applied and update debian and fedora templates.

Thanks Serge

   -- Daniel
