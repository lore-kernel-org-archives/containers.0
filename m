From: Kir Kolyshkin <kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] [PATCH 2/3] Introduce the res_counter_populate()
	function
Date: Thu, 04 Oct 2007 16:11:57 +0400
Message-ID: <4704D88D.1010005@openvz.org>
References: <4704AFC9.4030606@openvz.org> <4704B077.30502@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4704B077.30502-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> <...skipped...>
> +static char * units_names[RES_UNITS_MAX][RES_CFT_MAX] = {
> +	[RES_UNITS_BYTES] = {
> +		"usage_in_bytes",
> +		"limit_in_bytes",
> +		"failcnt",
> +	},
> +	[RES_UNITS_ITEMS] = {
> +		"usage",
> +		"limit",
> +		"failcnt",
> +	},
> +};
>   

Sorry for being late in the game, but can we please bring back the issue 
of naming those files?

To me, names like "usage_in_bytes" doesn't really make much sense, 
unless we will also have something like "usage_in_pages" next to it -- 
i.e. use several different units for the same resource. I seriously 
doubt we should...

Still, we need a way to denote units of measurement for each resource. 
Here are the options I can think of:

0. Hardcode the name of measurement units in file name, as it is 
(partially -- only for "bytes" done now). Looks ugly to me, access 
interface will be inconsistent, not program-friendly: as file name is 
not "usage", but "usage*", it will be easy to implement in shell, but 
requires some additional logic in C.

1. One obvious way is to put it in documentation, i.e. say something 
like "this parameter is measured in bytes". The problem is documentation 
is a bit far away from the actual file we read the value from.

2. Put units into the file itself, i.e. "cat usage" will print something 
like "1024 bytes". This is very user-friendly, but not really 
program-friendly: while in C it is just fscanf(fd, "%d", &val), shell 
users will require something like "cut -d ' ' -f1" to extract the 
numeric value.

3. Put units into a separate new files named "units" (or, well, 
"measurement_units" (or even "measured_in") if you are fan of long 
descriptive names). So, "cat units" will show us "bytes" or "items" or 
"pages"...

4. Encode units into a file name, like "measured_in_bytes". This would 
be a separate file which exist just for the sake of the name. This looks 
bad to be since getting this info from a program is complex.

I prefer approach #3 -- easy and consistent.
> <...skipped...>
>   
