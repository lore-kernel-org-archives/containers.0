From: Cameron Norman <camerontnorman-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [systemd-devel] systemd-cgroups-agent not working in containers
Date: Thu, 27 Nov 2014 12:26:01 -0800
Message-ID: <CALZWFRLVDW2fL_G0rC6mhMsBTPxsxYF1FATA1j-0unCS8WKAsg@mail.gmail.com>
References: <54764639.3020100@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <54764639.3020100-/L3Ra7n9ekc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Cc: "libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org" <systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>, Martin Pitt <mpitt-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Nov 26, 2014 at 1:29 PM, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org> wrote:
> Hi!
>
> I run a Linux container setup with openSUSE 13.1/2 as guest distro.
> After some time containers slow down.
> An investigation showed that the containers slow down because a lot of stale
> user sessions slow down almost all systemd tools, mostly systemctl.
> loginctl reports many thousand sessions.
> All in state "closing".

This sounds similar to an issue that systemd-shim in Debian had.
Martin Pitt (helps to maintain systemd in Debian) fixed that issue; he
may have some ideas here. I CC'd him.

The bug (at Martin's message with most relevant info) for reference:

https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=756076#75

Best regards,
--
Cameron Norman
