From: Alexey Dobriyan <adobriyan-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [Devel] [RFC][PATCH 3/3] Tune caches to be accountable or not
Date: Thu, 30 Aug 2007 14:02:12 +0400
Message-ID: <20070830100212.GA31518@localhost.sw.ru>
References: <46D68EA6.2010707@openvz.org> <46D6916C.3070806@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46D6916C.3070806-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Aug 30, 2007 at 01:44:12PM +0400, Pavel Emelyanov wrote:
> The /sys/slab/<name>/cache_account attribute controls
> whether the cache <name> is to be accounted or not.
> 
> For the reasons described in the zeroth letter kmalloc
> caches are excluded and are not allowed to be merged.
> 
> By default no caches are accountable. Simply make 
> # echo -n "on" >  /sys/slab/<name>cache_account
> to turn accounting on. Maybe its better to make it
> # echo -n "1" > ...
> ?

IMO, echo 1 >/sys/slab/*/account is the best. With obvious changes
in show function.
