From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] libcg: design and plans
Date: Wed, 05 Mar 2008 17:57:42 +0530
Message-ID: <47CE91BE.9050503@linux.vnet.ibm.com>
References: <20080304152341.GB5659@linux.vnet.ibm.com>
	<6599ad830803050401j2dbbfaa7ycdf0bbfce59539b2@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830803050401j2dbbfaa7ycdf0bbfce59539b2-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Sudhir Kumar <skumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Tue, Mar 4, 2008 at 7:23 AM, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>>  libcg will be written mainly in C with lex and yacc for parsing the configuration
>>  files.
>>
> 
> One suggestion - for configuration management tools like this I'd opt
> for C++ or Python over C, in order to be able to use STL (or the
> python libraries). Object-Orientation may be useful or maybe not, but
> classes like string, vector, hash_map, etc, make life so much easier.
> 
> Paul

Object-orientation is not very useful in this case. STIL is useful, if we don't
find equivalent functionality, we might consider using C++ or the C++ compiler
and libraries and export "C" interfaces. But for now, our plan is to use the C
compiler

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
