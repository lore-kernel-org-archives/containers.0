From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] The control group itself
Date: Thu, 21 Feb 2008 12:47:07 -0800
Message-ID: <6599ad830802211247t21fdc4e4hfe637fcffd98ded7@mail.gmail.com>
References: <47AAFFF2.9030804@openvz.org> <47AB013B.8060502@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47AB013B.8060502-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Feb 7, 2008 at 5:01 AM, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
>  +
>  +[cb] <major>:(<minor>|*) [r-][w-]
>  + ^          ^               ^
>  + |          |               |
>  + |          |               +--- access rights (1)
>  + |          |
>  + |          +-- device major and minor numbers (2)
>  + |
>  + +-- device type (character / block)
> ...
>  +When reading from it, one may see something like
>  +
>  +       c 1:5 rw
>  +       b 8:* r-
>  +

In the interest of avoiding proliferating cgroup control file formats,
I'm wondering if we can abstract out the general form of the data
being presented here and maybe simplify it in such a way that we can
hopefully reuse the format for other control files in the future?

For example, one way to represent this would be a map from device
strings such c:1:5 to permission strings such as rw. Or maybe
numerical device ids to numerical permission values.

The alternative might be to accept that there are two kinds of control
files - those which are likely to be programmatically read (e.g.
resource usage values), and those that are likely to be
programmatically written but only actually read by humans for
debugging purposes (like this one) and make it clear up-front when a
control file is added which type they're considered to be. We could
then ignore the API consistency requirements for the
debugging-readable files.

On a separate note, can you document the recommended way to completely
overwrite the set of device permissions for a cgroup? Does this
involves writing a "--" permission for every device that you don't
want in the cgroup?

Paul
