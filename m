From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 4/5] Setup the control group
Date: Mon, 1 Oct 2007 09:04:12 -0700
Message-ID: <6599ad830710010904m39cd9e39g55ef707e1ab37164@mail.gmail.com>
References: <46F91841.9070708@openvz.org> <46F91A1E.2060303@openvz.org>
	<4700FAAC.2050004@linux.vnet.ibm.com> <4700FB72.5070409@openvz.org>
	<4701013A.3010307@linux.vnet.ibm.com> <47010169.5040102@openvz.org>
	<47010276.8060802@linux.vnet.ibm.com>
	<6599ad830710010850q660d042av9fa5a461d3c3e445@mail.gmail.com>
	<47011812.2010406@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47011812.2010406-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On 10/1/07, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>
> Excellent, I prefer the later as well, but it would mean overheads
> for controllers not using the hierarchy.

I don't think it would have to with the ideas I've been thinking about
- each task would still have a set of pointers to subsystems which
could be dereferenced just as quickly. The complexity comes in trying
to map a task to its actual cgroup object in a given hierarchy - this
would involve a bit more work on the part of the cgroup framework, but
wouldn't be a fast path operation.

See my mail last week titled "Thoughts on virtualizing task containers".

> a design such that parents<->children can effectively share resources,
> track them and do so recursively, that would be really nice.

I think the recursive tracking would probably need to be supplied by
the subsystem rather than by the framework. But there's no reason that
multiple subsystems couldn't re-use the same hierarchy code via e.g.
resource counters. So when you initialize a resource counter you'd
tell it about its parent resource counter, and it would handle the
recursion automatically in charge/uncharge.

Paul
