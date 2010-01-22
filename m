From: william <william-FuVYq0B8HF8swF9hGuCkNA@public.gmane.org>
Subject: Re: cgroups and limit firefox  processes cpu time
Date: Fri, 22 Jan 2010 12:33:33 +0100
Message-ID: <4B598D0D.9080206@cobradevil.org>
References: <4B5938EB.3040809@cobradevil.org>
	<4B5988DC.8020100@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B5988DC.8020100-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, V Srivatsa <vsrivatsa-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Bharata B Rao <bharata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Dhaval Giani <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Balbir Singh wrote:
> On Friday 22 January 2010 11:04 AM, william wrote:
>   
>> Hello list
>>
>> I have a question about how i can limit the cpu for a firefox process on 
>> a terminal server.
>>
>> We have 150 firefox processes running on a terminalserver but there are 
>> always people who take more cpu when they use flash or java.
>> Some firefox processes take sometimes about 50 percent cpu time.
>> Is there a way to give all firefox processes equal cpu shares so that 
>> other people who are using firefox for research have no issues (slow 
>> responding scrolling and menu)  because there are a few firefox 
>> processes eating all the cpu time?
>>     
>
> Are these running on behalf of different users? You can always create a
> good hiearchy and organize. FAIR_USER scheduler option is going away
> soon. Some more context on the firefox applications and whose behalf
> they are running on, etc would help.
>
>
>   
The terminal server only hosts firefox processes for different users 
(user is only allowed to login once) to provide internet access in a 
secure way.

So i have 150 firefox processes for different users. So i cannot set one 
group, I have to put all those processes in a separate container if i 
get it right?

William
