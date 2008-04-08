From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: Loadable cgroup subsystems
Date: Tue, 08 Apr 2008 14:37:12 +0530
Message-ID: <47FB35C0.3030609@linux.vnet.ibm.com>
References: <1207633175.7798.5.camel@nikanth-laptop.blr.novell.com>
	<6599ad830804072243i35e5b134q1d04f2bd121f8f69@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830804072243i35e5b134q1d04f2bd121f8f69-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Mon, Apr 7, 2008 at 10:39 PM, Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org> wrote:
>>  Why not provide a interface to add subsystems at run-time instead?
>>  Are there any reason for not letting a subsystem to be implemented as a
>>  loadable module? IOW make cgroups usable by modules?
>>
> 
> Having all the subsystems declared at compile time makes a lot of
> things (number of subsystems, size of css_set, etc) statically known,
> which makes the code clearer and more importantly eliminates a bunch
> of locking/synchronization overhead.
> 
> It would be possible to make cgroups support dynamically-loaded
> subsystems, and in fact, some of the earliest cgroups patches did
> support this, for a predefined max number of subsystems. But it would
> introduce more complexity and overhead.
> 
> I'd rather not add support for this without a strong case of a
> subsystem that really needs to be dynamically loaded.
> 

I agree with most of what you just said. The biggest advantage I see of dynamic
modules is that they can be unloaded/loaded on demand. The biggest disadvantage
is that they come in much later after system initialization and might not be
fully aware of the state of the system when the specific controller is loaded.
It is trade-off, we need to see if it is worth doing.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
