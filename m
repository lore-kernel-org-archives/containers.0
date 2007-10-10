From: Herbert Poetzl <herbert-dBHVzrDq9nF4Lj/PQRBjDg@public.gmane.org>
Subject: Re: Idle time statistics for a container
Date: Wed, 10 Oct 2007 20:00:39 +0200
Message-ID: <20071010180039.GG27755@MAIL.13thfloor.at>
References: <20071010142529.GA4690@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20071010142529.GA4690-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Oct 10, 2007 at 07:55:29PM +0530, Srivatsa Vaddagiri wrote:
> Hi Kirill/Hertbert,
> 	Does Openvz or Linux-VServer provide idle time 
>       statistics per container? 

Linux-VServer accounts the time/ticks a contain was
running and on hold for being over limits, the time
running is broken down into sys/user/etc ...

>       i.e how much time a container has been idle?

so, while it is not accounted per se, it can be easily
calculated from the other vaules ...

> Just exploring whether that be a usefull stats to provide 
> on a per-control group basis.

I think it makes perfectly sense to account that, and
a smart version is required to get the statistics
inside a container right :)

best,
Herbert

> -- 
> Regards,
> vatsa
