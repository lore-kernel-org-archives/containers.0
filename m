From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Testing CGROUP inside CONTAINER]: BUG#1
Date: Thu, 04 Dec 2008 05:34:23 -0800
Message-ID: <1228397664.13111.32.camel@nimitz>
References: <1228378478.4234.35.camel@localhost.localdomain>
	<4937DA54.8060801@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4937DA54.8060801-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: gowrishankar <gomuthuk-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: iranna.ankad-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, sudhirkumarmalik-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dhavalgiani-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, risrajak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2008-12-04 at 18:55 +0530, gowrishankar wrote:
> It is expected behaviour of container, as PIDs in other namespaces will 
> always be shown as 0.
> So here, these 0s are from system ns (probably, as you had only system 
> ns and delta ns).

I think it is pretty bogus to be showing the 0's.  It is "expected" only
when we got access to a task which we were not supposed to receive.

Rishi, is this any different in behavior if you do the cgroup mount
after creating the container?

-- Dave
