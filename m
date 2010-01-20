From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] C/R: Basic support for network namespaces and devices
Date: Wed, 20 Jan 2010 11:36:39 -0600
Message-ID: <20100120173639.GD8463@us.ibm.com>
References: <1263999673-11279-1-git-send-email-danms@us.ibm.com>
	<1263999673-11279-4-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1263999673-11279-4-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> When checkpointing a task tree with network namespaces, we hook into
> do_checkpoint_ns() along with the others.  Any devices in a given namespace
> are checkpointed (including their peer, in the case of veth) sequentially.
> Each network device stores a list of protocol addresses, as well as other
> information, such as hardware address.
> 
> This patch supports veth pairs, as well as the loopback adapter.  The
> loopback support is there to make sure that any additional addresses and
> state (such as up/down) is copied to the loopback adapter that we are
> given in the new network namespace.
> 
> On restart, we instantiate new network namespaces and veth pairs as
> necessary.  Any device we encounter that isn't in a network namespace
> that was checkpointed as part of a task is left in the namespace of the
> restarting process.  This will be the case for a veth half that exists
> in the init netns to provide network access to a container.
> 
> Still to do are:
> 
>   1. Routes
>   2. Netfilter rules
>   3. IPv6 addresses
>   4. Other virtual device types (e.g. bridges)
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Cool - I don't see any issues in the patchset.

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

thanks,
-serge
