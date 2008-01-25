From: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 3/7 net-2.6.25] [IPV4]: Prohibit assignment of 0.0.0.0
 as interface address.
Date: Fri, 25 Jan 2008 08:34:04 -0800
Message-ID: <20080125083404.5f3c6176__44891.0396699377$1201278995$gmane$org@deepthought>
References: <1201269123-20378-1-git-send-email-den@openvz.org>
	<1201269123-20378-3-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1201269123-20378-3-git-send-email-den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 25 Jan 2008 16:51:59 +0300
"Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:

> I could hardly imagine why sombady needs to assign 0.0.0.0 as an interface
> address or interface destination address. The kernel will behave in a strage
> way in several places if this is possible, as ifa_local != 0 is considered
> as initialized/non-initialized state of the ifa.
> 
> Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
>

This is used as a way to bring device up in lots of existing documentation.
So please don't change.

-- 
Stephen Hemminger <stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
