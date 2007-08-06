From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH 1/15] Move exit_task_namespaces()
Date: Mon, 6 Aug 2007 16:54:19 +0400
Message-ID: <20070806125419.GB91@tv-sign.ru>
References: <46A8B37B.6050108@openvz.org> <46A8B3C4.5080601@openvz.org>
	<20070802162023.GB137@tv-sign.ru> <46B6D52C.3010405@openvz.org>
	<20070806095421.GA85@tv-sign.ru> <46B6F0DA.4080904@openvz.org>
	<20070806103838.GA129@tv-sign.ru> <46B7044A.4030508@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46B7044A.4030508-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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

On 08/06, Pavel Emelyanov wrote:
>
> If task X is exiting and has already exit_task_namespaces()-ed task
> Y will OOPs during its exit in determining parent's namespace. I agree 
> that in that case this is not important what namespace X belongs to, 
> but we need to handle the race with changing the nsproxy from not-NULL
> to NULL. This is OK to make this under task_lock() but what to add 
> extra locking for if we can avoid it?

No, we can't take task_lock() under write_lock(tasklist).

Oleg.
