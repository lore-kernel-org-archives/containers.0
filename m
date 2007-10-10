From: Kirill Korotaev <dev-3ImXcnM4P+0@public.gmane.org>
Subject: Re: Idle time statistics for a container
Date: Wed, 10 Oct 2007 19:35:14 +0400
Message-ID: <470CF132.5050003@sw.ru>
References: <20071010142529.GA4690@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
To: vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

yes, OpenVZ calculates idle statistics for VE.
it is calculated as follows:
cpu user/system time are incremented as usual on timer tick,
idle time is incremented on per-VE per-VCPU runqueue when there is no tasks
in VE runqueue.

i.e. VE idle time is the time when there were no VE tasks on the runqueue.

Srivatsa Vaddagiri wrote:
> Hi Kirill/Hertbert,
> 	Does Openvz or Linux-VServer provide idle time statistics per
> container? i.e how much time a container has been idle?
> 
> Just exploring whether that be a usefull stats to provide on a
> per-control group basis.
> 
