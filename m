From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] [PATCH 0/5] Kernel memory accounting container (v5)
Date: Fri, 05 Oct 2007 17:17:48 +0400
Message-ID: <4706397C.80306@openvz.org>
References: <46F91841.9070708@openvz.org>	
	<6599ad830710010932t150aba2eid18864a90f169c64@mail.gmail.com>	
	<47023EBE.7000708@openvz.org>
	<6599ad830710050011x68a80013w3b60d663e2c087a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830710050011x68a80013w3b60d663e2c087a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On 10/2/07, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
>> Such a lookup would require a hastable or something similar. We already
>> have such a bad experience (with OpenVZ RSS fractions accounting for
>> example). Hash lookups imply the CPU caches screwup and hurt the performance.
>> See also the comment below.
> 
> I think you could do it with an array lookup if you assigned an index
> to each cache as it was created, and used that as an offset into a
> per-cgroup array.
> 
>> I thought the same some time ago and tried to make a per-beancounter kmem
>> caches. The result was awful - the memory waste was much larger than in the
>> case of pointer-per-object approach.
> 
> OK, fair enough.
> 
> Was this with a large number of bean counters? I imagine that with a
> small number, the waste might be rather more reasonable.

Yup. I do not remember the exact number, but this model didn't scale
well enough in respect to the number of beancounters.

> Paul
> 
