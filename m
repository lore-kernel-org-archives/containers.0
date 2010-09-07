From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 2/3] cgroup : make the mount options parsing more accurate
Date: Tue, 07 Sep 2010 22:24:19 +0200
Message-ID: <4C869F73.7010804@free.fr>
References: <1283585466-30265-1-git-send-email-daniel.lezcano@free.fr>	<1283585466-30265-2-git-send-email-daniel.lezcano@free.fr>
	<AANLkTi=2qWKXGBsqmbZjUs_H2VSDykheAABha079puT3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTi=2qWKXGBsqmbZjUs_H2VSDykheAABha079puT3-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 09/07/2010 09:38 PM, Paul Menage wrote:
> On Sat, Sep 4, 2010 at 12:31 AM, Daniel Lezcano<daniel.lezcano-GANU6spQydw@public.gmane.org>  wrote:
>    
>> The actual code does not detect 'all' with one subsystem name, which
>> is IMHO mutually exclusive and when an option is specified even if it
>> is not a subsystem name, we have to specify the 'all' option with the
>> other option.
>> eg:
>>   not detected : mount -t cgroup -o all,freezer cgroup /cgroup
>>   not flexible : mount -t cgroup -o noprefix,all cgroup /cgroup
>>
>> This patch fix this and makes the code a bit more clear by replacing
>> 'else if' indentation by 'continue' blocks in the loop.
>>      
> Can you fix this description to be clearer about the new behaviour of the code?
>
> Reviewed-by: Paul Menage<menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>    

Sure no problem.

Thanks for the review.
   -- Daniel
