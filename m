From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC] [PATCH 5/5] cgroups: subsystem dependencies
Date: Wed, 09 Dec 2009 09:40:44 +0800
Message-ID: <4B1F001C.8020304__22037.6873891384$1260322914$gmane$org@cn.fujitsu.com>
References: <20091204085349.GA18867@andrew.cmu.edu>
	<20091204085854.GE18912@andrew.cmu.edu>
	<4B1DEE09.4010508@cn.fujitsu.com>
	<20091209010817.GA8929@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091209010817.GA8929-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Ben Blum wrote:
> On Tue, Dec 08, 2009 at 02:11:21PM +0800, Li Zefan wrote:
>>> This patch adds a mechanism with which a subsystem can specify dependencies on
>>> other subsystems. Since subsystems can come and go, it would not be useful to
>>> refer to a depended-upon subsystem by subsys_id, so instead a NULL-terminated
>>> array of strings must be specified. Validation is done by scanning for each
>>> potential subsystem its list of subsystem names with strcmp at the end of
>>> parse_cgroupfs_options.
>> I once posted a patch to implement this feature, but it was
>> rejected by Andrew, because there was no user using it.
>>
>> And still there is no user, right?
> 
> Dunno - Paul mentioned it might be useful in the future, so I threw this
> together in an hour or so. Not entirely sure what he had in mind, but
> this series can go with or without this particular patch.
> 

So I think Andrew's suggestion still applies: drop the
patch for now, until it finds its user.
