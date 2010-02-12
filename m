From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [lxc-devel] [PATCH 1/1] lxc-ps: Nit - Avoid blank CONTAINER column
Date: Fri, 12 Feb 2010 17:54:36 +0100
Message-ID: <4B7587CC.6070706__41497.5797328681$1265993813$gmane$org@fr.ibm.com>
References: <20100211042531.GA8835@us.ibm.com>	<1265882900.2591.65.camel@pagloppaglop>	<1265883662.2591.68.camel@pagloppaglop>
	<20100211155446.GC6884@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100211155446.GC6884-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, dlezcano-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

>> In fact there is no error in the script :)
>> The -n option for lxc-ps is a ps option !
>
> heh, good catch - given -n is pretty ubiquitous in lxc
> commands it should probably be used here :)
>
> And a '--' should be allowed to separate lxc-ps options from
> /bin/ps ones.

lxc-ps is just an enhanced ps and, ultimately, lxc-ps should disappear and
be replaced by a new ps option, like the -z on solaris. this is similar to
the -Z for listing the security context of a file the with ls

I agree with suka that -n shouldn't be used as a short option for --name.
because the result is confusing.

C.  
