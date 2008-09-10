From: "KOSAKI Motohiro" <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH][RFC] memory.min_usage again
Date: Wed, 10 Sep 2008 17:53:22 +0900
Message-ID: <2f11576a0809100153k16d03a11r322081d5e19bf801@mail.gmail.com>
References: <20071204040934.44AF41D0BA3@siro.lan>
	<20080910084443.8F7D85ACE@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080910084443.8F7D85ACE-Pcsii4f/SVk@public.gmane.org>
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
To: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Hi

>> here's a patch to implement memory.min_usage,
>> which controls the minimum memory usage for a cgroup.
>>
>> it works similarly to mlock;
>> global memory reclamation doesn't reclaim memory from
>> cgroups whose memory usage is below the value.
>> setting it too high is a dangerous operation.
>>
>> it's against 2.6.24-rc3-mm2 + memory.swappiness patch i posted here yesterday.
>> but it's logically independent from the swappiness patch.
>>
>> todo:
>> - restrict non-root user's operation ragardless of owner of cgroupfs files?
>> - make oom killer aware of this?

This is  really no good patch description.
You should write
 - Why you think it is useful.
 - Who need it.

A reviewer oftern want check to match coder's intention and actual code.
