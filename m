From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: containers development plans (July 20 version)
Date: Fri, 20 Jul 2007 17:02:32 -0700
Message-ID: <6599ad830707201702g1acae7ddt16a502984baa64cc@mail.gmail.com>
References: <20070720173615.GA25167@vino.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070720173615.GA25167-4+H9nbzk0uAIagZqoN9o3w@public.gmane.org>
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
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: ckrm-tech-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, xemul-3ImXcnM4P+0@public.gmane.org, rohitseth-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, pj-sJ/iWh9BUns@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, cpw-sJ/iWh9BUns@public.gmane.org
List-Id: containers.vger.kernel.org

On 7/20/07, Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
>         4. task containers functionality
>                 base features
>                         virtualized continerfs mounts
>                                 to support vserver mgmnt of sub-containers
>                         locking cleanup
>                         control file API simplification
>                         control file prefixing with subsystem name

This last point was actually in the set of patches that I sent to akpm
today - probably it was too small an item to be worth including in
this list.

> Stakeholders:
>         Eric Biederman
>                 everything
>         google
>                 task containers

If the checkpoint/restart code is expected to evolve into a workable
live migration system, we'd be interested in that too.

Paul
