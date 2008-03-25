From: Alexey Dobriyan <adobriyan-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [Devel] [PATCH 6/7]: Check for user-space mount of /dev/pts
Date: Tue, 25 Mar 2008 12:40:19 +0300
Message-ID: <200803251240.19434.adobriyan@sw.ru>
References: <20080325035904.GB27451@us.ibm.com>
	<20080325042614.GF27864@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080325042614.GF27864-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
To: devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tuesday 25 March 2008 07:26:14 sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Subject: [PATCH 6/7]: Check for user-space mount of /dev/pts
>
> When the pts namespace is cloned, the /dev/pts is not useful unless it
> is remounted from the user space.
>
> If user-space clones pts namespace but does not remount /dev/pts, it
> would end up using the /dev/pts mount from parent-pts-ns but allocate
> the pts indices from current pts ns.
>
> This patch (hack ?) prevents creation of PTYs in user space unless
> user-space mounts /dev/pts.

This is absolutely horrible and shouldn't go anywhere.
