From: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] Account for the slub objects
Date: Mon, 17 Sep 2007 09:09:28 -0700
Message-ID: <1190045368.26982.59.camel@localhost>
References: <46EE70B4.6060902@openvz.org>  <46EE74AF.70105@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46EE74AF.70105-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2007-09-17 at 16:35 +0400, Pavel Emelyanov wrote:
> 
> +
> +       rcu_read_lock();
> +       cnt = task_kmem_container(current);
> +       if (res_counter_charge(&cnt->res, s->size))
> +               goto err_locked;
> +
> +       css_get(&cnt->css);
> +       rcu_read_unlock();
> +       obj_container[slab_index(obj, s, page_address(pg))] = cnt; 

You made some effort in the description, but could we get some big fat
comments here about what RCU is doing?

-- Dave
