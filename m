From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: lxc : linux containers tool 0.6.0 release
Date: Mon, 23 Mar 2009 16:18:10 +0800
Message-ID: <20090323081810.GB2231@hack>
References: <499EC673.8020808@fr.ibm.com>
	<d95d44a20903230048ke520376gd7701de00ff4e72d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <d95d44a20903230048ke520376gd7701de00ff4e72d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 23, 2009 at 03:48:44PM +0800, anqin wrote:
>Hi Danial,
>
>I have tried to install the lxc-0.6.0, and fount it needs to prepare
>a "libcap-2". I don't very understand what exactly version of libcap-2
>points to.
>
>I have searched the repository (via yum, in CentOS5.1) but not found
>the libcap version >= 2.0. So, is there anything missing?

Yes?

% rpm -q libcap
libcap-2.10-2.fc10.i386

Even if you don't have it in your repository, you could also try
to compile it by yourself, try:

http://ftp.kernel.org/pub/linux/libs/security/linux-privs/kernel-2.6/

-- 
Do what you love, f**k the rest! F**k the regulations!
