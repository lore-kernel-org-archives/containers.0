From: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: plan9 semantics on Linux - mount namespaces
Date: Wed, 14 Feb 2018 12:30:18 +0100
Message-ID: <CAFLxGvzxLP_UTQbwEY99bQfyftWzZHwaOP+WrzJ8099EKtbVLg__42386.0876159326$1518607751$gmane$org@mail.gmail.com>
References: <0f058286-a432-379b-f559-f2fe713807ab@metux.net>
	<5633d335-3926-d98f-d6d7-948b1e2a0b2c@metux.net>
	<20180213222751.p3fyg7whg6jqlzz5@gordon>
	<39b08c53-3449-3164-c1b1-44ac587dd4ea@metux.net>
	<20180214045442.jyv6zpbwz5glzi4z@gordon>
	<9c097fd9-3035-d5be-a829-fc18e7734f18@metux.net>
	<20180214102410.dxgbayb4i76h5exo@gordon>
	<24ddea73-5c84-e098-caae-8a4c14834cbd@metux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <24ddea73-5c84-e098-caae-8a4c14834cbd-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Enrico Weigelt <lkml-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Feb 14, 2018 at 12:27 PM, Enrico Weigelt <lkml-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org> wrote:
> On 14.02.2018 11:24, Aleksa Sarai wrote:
>
>> What distribution are you using and which release?
>
>
> On a self-compiled system.
>
> Forgot to enable namespaces in the kernel. Now it seems to work
> as root, but not as an unprivileged user:
>
>
> daemon@alphabox:~ unshare -r -U
> unshare: can't open '/proc/self/setgroups': Permission denied
> daemon@alphabox:~ unshare -f -r -U
> unshare: can't open '/proc/self/setgroups': Permission denied
>

Please read http://man7.org/linux/man-pages/man7/user_namespaces.7.html
setgroups is a corner case and needs special care.

-- 
Thanks,
//richard
