From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v3 00/32] memcg-aware slab shrinking with lasers and
	numbers
Date: Tue, 9 Apr 2013 11:25:09 +0400
Message-ID: <5163C255.1010806@parallels.com>
References: <1365429659-22108-1-git-send-email-glommer@parallels.com>
	<20130408135128.a5a8b0e5b041f58f9e976bf7@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130408135128.a5a8b0e5b041f58f9e976bf7-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Shrinnker <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 04/09/2013 12:51 AM, Andrew Morton wrote:
> On Mon,  8 Apr 2013 18:00:27 +0400 Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:
> 
>> Cc: Dave Shrinnker <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
> 
> I keep on receiving emails from people who claim they can fix this.
> 

=)

>> This patchset implements targeted shrinking for memcg when kmem limits are
>> present. So far, we've been accounting kernel objects but failing allocations
>> when short of memory. This is because our only option would be to call the
>> global shrinker, depleting objects from all caches and breaking isolation.
> 
> This is a fine-looking patchset and it even has some acks and reviews. 
> But it's huuuuge and we're at -rc6 and I've been offline for a week and
> have 975 emails in my to-apply folder.
> 
> So, err, I think I'll bestow upon everyone some additional time to
> review the code ;)  Please resend for -rc1?
> 
Sure. This was still a mostly asynchronous submission. I also believe I
would have to rebase on top of Li Zefan's patchset that made some very
important refcount cleanups in memcg.
